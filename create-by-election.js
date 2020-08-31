module.exports = (label, date) => {
  return {
    type: 'item',
    labels: {
      en: label
    },
    claims: {
      P31: { value: 'Q7864918' },
      P17: { value: 'Q145' },
      P585: { value: date }
    }
  }
}
